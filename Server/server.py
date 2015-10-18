import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def Welcome():
    return 'WeatherWay on Bluemix!'

@app.route('/myapp')
def WelcomeToMyapp():
    return 'do things here'

port = os.getenv('VCAP_APP_PORT', '5000')
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(port))