# DSA Docker Image

This is a Docker image which runs multiple DSLinks in a single container, along with a broker.

## Usage

```bash
docker pull iotdsa/links:latest
docker run -it --name="dsa-links" \
  -v ~/docker/dsa-data:/app/links \
  iotdsa/links:latest
```
