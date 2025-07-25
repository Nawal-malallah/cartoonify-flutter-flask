# 🎨 Cartoonify App – Flutter + Flask + OpenCV

This is a cross-platform app that lets users **convert any image into a cartoon-style version** using a Flutter frontend and a Python Flask backend with OpenCV filters.

---

## 🚀 Features

- 📷 Pick image from gallery
- 📤 Upload to Flask server
- 🖌️ Convert image to cartoon using OpenCV
- ⬇️ Download and save cartoon image
- 🖥️ Works locally over Wi-Fi

---

## 🛠️ Tech Stack

| Layer     | Technology              |
|-----------|--------------------------|
| Frontend  | Flutter (Dart)           |
| Backend   | Python Flask             |
| Processing| OpenCV                  |
| Networking| HTTP Multipart API       |
| Storage   | Temporary files + Downloads folder |

---

## 📂 Project Structure

```
Cartoonify-App/
├── cartoon_api.py           # Flask backend for cartoon conversion
├── lib/
│   └── cartoon.dart         # Flutter UI screen
├── uploads/                 # Temp folder for uploaded/processed images (ignored)
├── README.md
├── LICENSE
├── pubspec.yaml
├── .gitignore
```

---

## 📲 How to Run the App

### ▶️ Flutter App

```bash
cd Cartoonify-App
flutter pub get
flutter run
```

### ⚙️ Flask Backend

```bash
cd Cartoonify-App
pip install flask opencv-python
python cartoon_api.py
```

> Make sure your phone and PC are connected to the same Wi-Fi  
> Update the IP in Flutter code to match your server IP (e.g., `http://192.168.1.6:5000/cartoonify`)

---

## 🖼️ Demo

| Pick Image | Convert to Cartoon | Download |
|------------|--------------------|----------|
| ✅ Gallery picker | ✅ Uploads image to Flask | ✅ Saves image locally |

---

## 🔐 License

This project is licensed under the [MIT License](./LICENSE).

---

## 👨‍💻 Author

**Mark Amgad George**  
📍 Alexandria, Egypt  
💼 [Portfolio](https://mark-a-portfolio.netlify.app/)  
🐙 [GitHub](https://github.com/markamgad1234)  
📧 markamgad18@gmail.com
