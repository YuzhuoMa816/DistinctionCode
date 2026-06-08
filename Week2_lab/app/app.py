from flask import Flask, jsonify
import mysql.connector
import os

app = Flask(__name__)

db_config = {
    "host": os.getenv("DB_HOST", "db"),
    "user": os.getenv("MYSQL_USER", "devopsuser"),
    "password": os.getenv("MYSQL_PASSWORD", "devopspassword"),
    "database": os.getenv("DB_NAME", "testdb"),
    "port": int(os.getenv("DB_PORT", 3306))
}


def check_db_connection():
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    cursor.execute("SELECT VERSION()")
    version = cursor.fetchone()[0]
    cursor.close()
    connection.close()
    return version


@app.route("/")
def home():
    try:
        version = check_db_connection()
        return f"""
        <html>
            <head><title>DevOps Lab</title></head>
            <body style="font-family: Arial; text-align: center; padding: 50px;">
                <h1 style="color: #028090;">Welcome to DevOps Lab!</h1>
                <p style="font-size: 20px; color: green;">Connected to Database ✅</p>
                <p>MySQL Version: {version}</p>
                <p><a href="/health">Check Health</a> | <a href="/db-test">Test Database</a></p>
            </body>
        </html>
        """
    except Exception as e:
        return f"""
        <html>
            <head><title>DevOps Lab</title></head>
            <body style="font-family: Arial; text-align: center; padding: 50px;">
                <h1 style="color: #028090;">Welcome to DevOps Lab!</h1>
                <p style="font-size: 20px; color: red;">Database Connection Failed ❌</p>
                <p>{str(e)}</p>
                <p><a href="/health">Check Health</a> | <a href="/db-test">Test Database</a></p>
            </body>
        </html>
        """, 500


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/db-test")
def db_test():
    try:
        version = check_db_connection()
        return jsonify({
            "status": "success",
            "message": "Database connection successful",
            "mysql_version": version
        }), 200
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)