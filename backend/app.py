import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
import torchxrayvision as xrv
from PIL import Image
import numpy as np
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize the model and move to appropriate device
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = xrv.models.DenseNet(weights="densenet121-res224-all")
model = model.to(device)
model.eval()  # Set model to evaluation mode

def preprocess_image(image):
    # Convert image to grayscale
    if image.mode != 'L':
        image = image.convert('L')
    
    # Resize image to 224x224 (required by the model)
    image = image.resize((224, 224))
    
    # Convert to numpy array and normalize
    img_array = np.array(image)
    img_array = img_array.astype(np.float32) / 255.0
    
    # Convert to torch tensor and add batch and channel dimensions
    img_tensor = torch.from_numpy(img_array).unsqueeze(0).unsqueeze(0)  # Add channel dimension
    img_tensor = img_tensor.to(device)  # Move tensor to the same device as model
    
    return img_tensor

@app.route('/predict', methods=['POST'])
def predict():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image provided'}), 400
        
        # Get the image file
        image_file = request.files['image']
        image = Image.open(image_file)
        
        # Preprocess the image
        img_tensor = preprocess_image(image)
        
        # Get prediction
        with torch.no_grad():
            outputs = model(img_tensor)
            probabilities = torch.sigmoid(outputs)
            probabilities = probabilities.cpu()  # Move probabilities back to CPU for numpy conversion
        
        # Get the top 3 predictions
        probs = probabilities[0].numpy()
        top_indices = np.argsort(probs)[-3:][::-1]
        
        # Get the condition names
        conditions = model.pathologies
        
        # Prepare the response
        predictions = []
        for idx in top_indices:
            predictions.append({
                'condition': conditions[idx],
                'confidence': float(probs[idx]),
                'description': get_condition_description(conditions[idx])
            })
        
        return jsonify({'predictions': predictions})
    
    except Exception as e:
        print(f"Error during prediction: {str(e)}")  # Add logging
        return jsonify({'error': str(e)}), 500

def get_condition_description(condition):
    # Dictionary of condition descriptions (Thai)
    descriptions = {
        'Atelectasis': 'ภาวะปอดแฟบ: การยุบตัวของเนื้อเยื่อปอด ส่งผลกระทบต่อบางส่วนหรือทั้งหมดของปอดข้างหนึ่ง',
        'Consolidation': 'ภาวะปอดบวมแข็ง: ของเหลวหรือของแข็งในช่องอากาศของปอด',
        'Infiltration': 'การแทรกซึมในปอด: สารที่มีความหนาแน่นกว่าอากาศในปอด',
        'Pneumothorax': 'ภาวะลมรั่วในช่องเยื่อหุ้มปอด: อากาศระหว่างปอดและผนังทรวงอก',
        'Edema': 'ภาวะบวมน้ำ: การสะสมของเหลวในปอด',
        'Emphysema': 'ภาวะถุงลมโป่งพอง: ความเสียหายต่อถุงลมในปอด',
        'Fibrosis': 'ภาวะพังผืดในปอด: การเกิดแผลเป็นในเนื้อเยื่อปอด',
        'Effusion': 'ภาวะน้ำในช่องเยื่อหุ้มปอด: การสะสมของเหลวในช่องเยื่อหุ้มปอด',
        'Pneumonia': 'ปอดบวม: การติดเชื้อที่ทำให้ถุงลมในปอดอักเสบ',
        'Pleural_Thickening': 'ภาวะเยื่อหุ้มปอดหนาตัว: การหนาตัวของเยื่อหุ้มปอด',
        'Cardiomegaly': 'ภาวะหัวใจโต: การขยายขนาดของหัวใจ',
        'Nodule': 'ตุ่มในปอด: การเจริญเติบโตขนาดเล็กและกลมในปอด',
        'Mass': 'ก้อนเนื้อในปอด: การเจริญเติบโตที่ผิดปกติในปอด',
        'Hernia': 'ไส้เลื่อน: การยื่นออกมาของอวัยวะผ่านผนังของช่อง (ในร่างกาย)',
        'Lung Lesion': 'รอยโรคในปอด: ความผิดปกติหรือความเสียหายในเนื้อเยื่อปอด',
        'Fracture': 'กระดูกหัก: การแตกของกระดูก',
        'Lung Opacity': 'ความทึบในปอด: บริเวณที่ดูขาวขึ้นในภาพถ่ายรังสีปอด ซึ่งอาจบ่งบอกถึงความผิดปกติ',
        'Enlarged Cardiomediastinum': 'ภาวะช่องทรวงอกส่วนกลางและหัวใจโต: การขยายขนาดของโครงสร้างในช่องอกส่วนกลาง ซึ่งรวมถึงหัวใจ',
    }

    return descriptions.get(condition, 'ไม่มีคำอธิบาย')

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False) 