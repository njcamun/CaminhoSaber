@echo off
rem ----------------------------------------------------
rem  Inicia servidor HTTP simples com Python na porta 8000
rem ----------------------------------------------------
echo Iniciando servidor Python na porta 8000...
python -m http.server 8000
pause
