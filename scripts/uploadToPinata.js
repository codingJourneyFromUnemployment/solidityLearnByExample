const axios = require('axios')
const FormData = require('form-data')
const fs = require('fs')
const colors = require('colors');

require('dotenv').config({ path: '../.env' });

const JWT = process.env.JWT_SECRET;

const pinFileToIPFS = async () => {
  const formData = new FormData();
  const src = "../assets/images/andy.jpg"

  const file = fs.createReadStream(src)
  formData.append('file', file)

  const pinataMetadata = JSON.stringify({
    name: 'File name',
  });
  formData.append('pinataMetadata', pinataMetadata);

  const pinataOptions = JSON.stringify({
    cidVersion: 0,
  })
  formData.append('pinataOptions', pinataOptions);

  try {
    const res = await axios.post("https://api.pinata.cloud/pinning/pinFileToIPFS", formData, {
      maxBodyLength: "Infinity",
      headers: {
        'Content-Type': `multipart/form-data; boundary=${formData._boundary}`,
        'Authorization': `Bearer ${JWT}`
      }
    });
    console.log(res.data);
  } catch (error) {
    console.log(error);
  }
}
pinFileToIPFS()
