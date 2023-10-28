const fs = require('fs');

const metadata = {
  name: "Andy",
  description: "This is my friend Andy's avatar NFT",
  image: "https://ipfs.io/ipfs/QmV6vu3qr9J7VsCDN2nat9hsRTUgAyYmu78py6QgFhccJK"
};

fs.writeFileSync('../assets/metadata/Andy', JSON.stringify(metadata));