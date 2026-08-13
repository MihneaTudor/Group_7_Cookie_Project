clear &&
echo "building..." && 
docker build -t backend . && 
echo "running..." && 
docker run backend