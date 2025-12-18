FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]

#Uses python v3.12 [slim] version (light weight ver vs large ver).
#changes working directory to our /app directory.
#Locally copies direct versions from requirements.txt and places it into app.py-- installs during runtime as direction from RUN pip install cmd. 
#Listens to port 8080 and for using Gunicorn (as production HTTP server)
