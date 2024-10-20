import os
from flask import Flask, request, send_file, jsonify
import pdfplumber
import docx
from werkzeug.utils import secure_filename
import google.generativeai as genai
from fpdf import FPDF

# Set your API key
os.environ["GOOGLE_API_KEY"] = "AIzaSyCfzCErNSYRZY1aKt4l-gzpQmS_oy4T00U"
genai.configure(api_key=os.environ["GOOGLE_API_KEY"])
model = genai.GenerativeModel("models/gemini-1.5-pro")

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads/'
app.config['RESULTS_FOLDER'] = 'results/'
app.config['ALLOWED_EXTENSIONS'] = {'pdf', 'txt', 'docx'}

if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

if not os.path.exists(app.config['RESULTS_FOLDER']):
    os.makedirs(app.config['RESULTS_FOLDER'])

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']

def extract_text_from_file(file_path):
    if file_path.endswith('.pdf'):
        try:
            with pdfplumber.open(file_path) as pdf:
                return "\n".join(page.extract_text() for page in pdf.pages if page.extract_text())
        except Exception as e:
            print(f"Error extracting text from PDF: {e}")
            return None
    elif file_path.endswith('.docx'):
        doc = docx.Document(file_path)
        return "\n".join([para.text for para in doc.paragraphs])
    elif file_path.endswith('.txt'):
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    return None

def Question_mcqs_generator(input_text, num_questions, difficulty):
    # Adjust the prompt based on difficulty level
    prompt = f"""
    You are an AI assistant helping the user generate multiple-choice questions (MCQs) based on the following text:
    '{input_text}'
    Please generate {num_questions} MCQs with '{difficulty}' difficulty level from the text. Each question should have:
    - A clear question
    - Four answer options (labeled A, B, C, D)
    - The correct answer clearly indicated
    Format:
    ## MCQ {num_questions}
    Question: [question]
    A) [option A]
    B) [option B]
    C) [option C]
    D) [option D]
    Correct Answer: [correct option]
    """
    response = model.generate_content(prompt).text.strip()
    return response

def save_mcqs_to_file(mcqs, num_questions):
    # Save as .txt file
    txt_filename = f"generated_mcqs_{num_questions}.txt"
    txt_filepath = os.path.join(app.config['RESULTS_FOLDER'], txt_filename)
    with open(txt_filepath, 'w', encoding='utf-8') as f:
        f.write(mcqs)
    
    # Save as .pdf file
    pdf_filename = f"generated_mcqs_{num_questions}.pdf"
    pdf_filepath = os.path.join(app.config['RESULTS_FOLDER'], pdf_filename)
    pdf = FPDF()
    pdf.add_page()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.set_font("Arial", size=12)
    pdf.multi_cell(0, 10, mcqs)
    pdf.output(pdf_filepath)

    return txt_filepath, pdf_filepath

@app.route('/generate', methods=['POST'])
def generate_mcqs():
    # Check if a file is included in the request
    file = request.files.get('file')

    # Extract text from the uploaded file if present
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)

        # Extract text from the uploaded file
        text = extract_text_from_file(file_path)
        if text is None or text.strip() == "":
            return "Error extracting text from file or empty file", 500
    else:
        # If no file is uploaded, check for manual text input
        text = request.form.get('text')
        if not text or text.strip() == "":
            return "No text input provided", 400  # Adjusted error message

    try:
        num_questions = int(request.form.get('num_questions', 1))  # Default to 1 if not provided
        difficulty = request.form.get('difficulty', 'Easy')  # Default to 'Easy'
        mcqs = Question_mcqs_generator(text, num_questions, difficulty)

        # Save the generated MCQs to both .txt and .pdf
        txt_filepath, pdf_filepath = save_mcqs_to_file(mcqs, num_questions)

        return jsonify({"mcqs": mcqs, "txt_file": txt_filepath, "pdf_file": pdf_filepath}), 200
    except Exception as e:
        print(f"Error generating MCQs: {e}")
        return "Error generating MCQs", 500

@app.route('/download/<file_type>/<filename>', methods=['GET'])
def download_file(file_type, filename):
    if file_type == 'txt':
        folder = app.config['RESULTS_FOLDER']
    elif file_type == 'pdf':
        folder = app.config['RESULTS_FOLDER']
    else:
        return "Invalid file type", 400

    file_path = os.path.join(folder, filename)
    if os.path.exists(file_path):
        return send_file(file_path, as_attachment=True)
    return "File not found", 404

if __name__ == "__main__":
    app.run(debug=True)
