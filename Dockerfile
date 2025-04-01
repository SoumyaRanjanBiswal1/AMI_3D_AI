

# Use NVIDIA's CUDA image with Python 3.11 and CUDA 12.4
FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

# Set the working directory inside the container
WORKDIR /app

# Update and install Python, pip, and OpenGL libraries
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libgl1-mesa-glx

# Install PyTorch with CUDA 12.4 support
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# Set CUDA environment variables
ENV CUDA_HOME=/usr/local/cuda
ENV PATH="${CUDA_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"

# Set PyTorch CUDA architecture list explicitly (adjust based on your GPU)
ENV TORCH_CUDA_ARCH_LIST="8.0"

# Copy only requirements first (for better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install SentencePiece (required for T5Tokenizer and similar components)
RUN pip install --no-cache-dir sentencepiece

# Copy the entire project directory into the container
COPY . .

# Build and install the custom rasterizer
RUN cd hy3dgen/texgen/custom_rasterizer && \
    python3 setup.py install && \
    cd ../../..

# Build and install the differentiable renderer
RUN cd hy3dgen/texgen/differentiable_renderer && \
    python3 setup.py install && \
    cd ../../..

# Expose the port for Gradio
EXPOSE 8080

# Run the Gradio app
CMD ["python3", "neophyte_3d.py", "--enable_t23d"]
