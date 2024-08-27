FROM mcr.microsoft.com/playwright/python:v1.30.0-focal

RUN apt-get update && \
    apt-get install -y git 

WORKDIR /app

RUN git clone https://github.com/vanthiyadhevan/playwright_python.git

WORKDIR /app/playwright_python/

#COPY pages /app/playwright_python/pages
#COPY tests /app/tests
#COPY utilities /app/utilities

#COPY requirements.txt /app/

RUN pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt
