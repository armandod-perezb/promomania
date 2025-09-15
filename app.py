from flask import Flask, request, jsonify, redirect, render_template
from Config.db import app

@app.route("/")
def index():
    return "Hola Mundo Web"

@app.route("/main")
def main():
    return render_template("main/layout.html")


if __name__ == "__main__":
    app.run(debug=True, port=5000, host='0.0.0.0')