import flask
from flask import request
import os
from bot import ObjectDetectionBot
import boto3
import json
from botocore.exceptions import ClientError

def get_secret():

    secret_name = "BotTelegram/token"
    region_name = "us-east-1"

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    secret = get_secret_value_response['SecretString']
    secret = json.loads(secret)
    return secret["token_telegram"]

TELEGRAM_TOKEN = get_secret()
# TELEGRAM_APP_URL = os.environ['TELEGRAM_APP_URL']
TELEGRAM_APP_URL = 'https://polybot.ygdn.online'

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')


app = flask.Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return 'Ok'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


@app.route(f'/results', methods=['POST'])
def results():
    prediction_id = request.args.get('prediction_id')

    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user
    table = dynamodb.Table('BotPhotoProject')
    response = table.get_item(Key={'prediction_id': prediction_id})

    chat_id = int(response['Item']['chat_id'])
    objects = response['Item']['labels']
    dictrespone = {}
    for x in range(len(objects)):
        try:
            dictrespone.update({objects[x]['class']: dictrespone[objects[x]['class']]+1})
        except:
            dictrespone[objects[x]['class']] = 1
    
    text_results = "The objects is:\n"
    for keys, values in dictrespone.items():
        text_results = f"{text_results}{keys}: {values}\n"

    # text_results = response['Item']['labels'][0]['class']
    bot.send_text(chat_id, text_results)
    return 'Ok'


@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)
    app.run(host='0.0.0.0', port=8443, debug=True)