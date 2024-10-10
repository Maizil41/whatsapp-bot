const express=require('express');const bodyParser=require('body-parser');const fs=require('fs');const QRCode=require('qrcode');const app=express();const PORT=3000;app.use(express.static('public'));app.use(bodyParser.json());function createServer(sock,connectToWhatsApp){app.get('/',(req,res)=>{res.send(`
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>WhatsApp</title><style>body{font-family:Arial,sans-serif;background-color:#e5ddd5;margin:0;padding:20px;display:flex;align-items:center;height:100vh;flex-direction:column;box-sizing:border-box}h1{text-align:center;color:#075e54;margin-bottom:20px}#messageForm{background-color:#fff;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,.1);padding:20px;max-width:400px;width:100%}label{font-weight:700;display:block;margin:10px 0 5px}input[type=text],textarea{width:100%;padding:10px;border:1px solid #ccc;border-radius:4px;margin-bottom:10px;box-sizing:border-box}textarea{resize:vertical}button{background-color:#075e54;color:#fff;border:none;border-radius:4px;padding:10px;width:100%;cursor:pointer;font-size:16px}button:hover{background-color:#0b8b6d}</style></head><body><h1>Kirim Pesan WhatsApp</h1><form id="messageForm"><label for="to">Nomor Tujuan:</label><input type="text" id="to" name="to" required placeholder="Contoh: 6281234567890"><label for="message">Pesan:</label><textarea id="message" name="message" required></textarea><button type="submit">Kirim Pesan</button></form><script>document.getElementById('messageForm').onsubmit = async function(event) {
            event.preventDefault();
            const to = document.getElementById('to').value;
            const message = document.getElementById('message').value;

            const response = await fetch('/send-message', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ to, message }),
            });
            const result = await response.text();
            
            alert(result);
            document.getElementById('message').value = '';
        };</script></body></html>
        `)});app.get('/login',(req,res)=>{res.send(`
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Login WhatsApp</title><style>body{font-family:Arial,sans-serif;background-color:#f0f0f0;margin:0;display:flex;justify-content:center;align-items:center;height:100vh;box-sizing:border-box;flex-direction:column}.container{background-color:#fff;border-radius:8px;box-shadow:0 4px 20px rgba(0,0,0,.1);padding:20px;text-align:center;width:90%;max-width:400px}h1{color:#075e54;margin-bottom:20px}img{width:100%;border-radius:8px}.loading{margin-bottom:20px}.loading-image{width:90%}#qrCode{display:none}@media (max-width:600px){.container{width:90%}}</style></head><body><div class="container"><h1>Scan QR Code</h1><div class="loading" id="loading"><img src="/loading.gif" class="loading-image" id="loading" alt="Loading"><p>Loading QR Code...</p></div><img id="qrCode" alt="QR Code"><p>Silakan scan kode QR di atas menggunakan aplikasi WhatsApp.</p></div><script>async function fetchQRCode() {
            const qrCodeImage = document.getElementById('qrCode');
            const loadingDiv = document.getElementById('loading');
            
            try {
                const response = await fetch('/qr.png?' + new Date().getTime(), { method: 'HEAD' });
                
                if (response.ok) {
                    qrCodeImage.src = '/qr.png?' + new Date().getTime();
                    qrCodeImage.style.display = 'block';
                    loadingDiv.style.display = 'none';
                } else {
                    qrCodeImage.style.display = 'none';
                    loadingDiv.style.display = 'block';
                }
            } catch (error) {
                console.error('Error fetching QR code:', error);
                qrCodeImage.style.display = 'none';
                loadingDiv.style.display = 'block';
            }
        }
        
        fetchQRCode();
        setInterval(fetchQRCode, 5000);</script></body></html>
        `)});app.get('/qr.png',(req,res)=>{const qrPath='./public/qr_code.png';if(fs.existsSync(qrPath)){res.sendFile(qrPath,{root:__dirname})}else{res.status(404).send('QR Code tidak ditemukan.')}});app.post('/send-message',async(req,res)=>{const{to,message}=req.body;if(!sock||sock.authState==='Disconnected'){await connectToWhatsApp();if(sock.authState==='Disconnected'){return res.status(500).send('Koneksi WhatsApp tidak tersedia, coba lagi nanti')}}
try{await sock.sendMessage(to+'@s.whatsapp.net',{text:message});res.send('Pesan terkirim!')}catch(error){res.status(500).send('Gagal mengirim pesan')}});app.listen(PORT,()=>{console.log(`Server running on port ${PORT}`)})}
module.exports=createServer