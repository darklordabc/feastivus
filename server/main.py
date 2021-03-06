# a simple server for darklord's feastivus game mode
# using python3, mongodb and flask
from flask import Flask, request, abort
from pymongo import MongoClient, DESCENDING
from bson import ObjectId
import json, math, time, datetime

import logging
from logging.config import dictConfig

logging_config = dict(
    version=1,
    formatters={
        'simple': {'format':'%(levelname)s %(asctime)s { module name : %(module)s Line no : %(lineno)d} %(message)s'}
    },
    handlers={
        'h': {'class': 'logging.handlers.RotatingFileHandler',
              'filename': '/home/xavier/feastivus/server/logger.log',
              'maxBytes': 1024 * 1024 * 5,
              'backupCount': 5,
              'level': 'DEBUG',
              'formatter': 'simple',
              'encoding': 'utf8'}
    },

    root={
        'handlers': ['h'],
        'level': logging.DEBUG,
    },
)

dictConfig(logging_config)
logger = logging.getLogger()

server_auth = 'BOV4k4oOWI!yPeWSXY*1eZOlB3pBW3!#'
app = Flask(__name__)

class database():
	def __init__(self):
		self.conn = MongoClient('localhost', 27030)

	# database to save player stats
	def player_db(self):
		now = datetime.datetime.now()
		# so we can have different leaderboard every month
		# use week key to make it update every week xD
		db = self.conn['feastivus']
		return db.players

	# database to save all games played
	def match_db(self):
		now = datetime.datetime.now()
		# so we can have different leaderboard every month
		# use week key to make it update every week xD
		now = str(now.year) + str(now.month) 
		db = self.conn['feastivus_' + now]
		return db.matches

	# database to store all deals' data
	def deals_db(self):
		db = self.conn['feastivus']
		return db.deals

	# database to store all scores!
	def score_db(self):
		now = datetime.datetime.now()
		# so we can have different leaderboard every month
		# use week key to make it update every week xD
		now = str(now.year) + str(now.month) 
		db = self.conn['feastivus_' + now]
		return db.score

Database = database() # make connection pool to database

# for testing purpose
@app.route('/', methods=['GET'])
def index():
	return "server for darklord's feastivus"

@app.route('/NewMatch', methods=['POST'])
def new_match():
	pass

@app.route('/EndMatch', methods=['POST'])
def end_match():
	pass

@app.route('/SaveScore', methods=['POST'])
def save_score():
	"""
	save score send by client
	return high score json
	"""

	if request.form.get("auth") != server_auth:
		abort(502)

	player_json = json.loads(request.form.get("player_json"))
	players = []
	for player in player_json:
		players.append(player)
	players.sort()
	score = request.form.get("score")
	level = request.form.get("level")

	data = Database.score_db().find_one({"players":players, "level": level})
	if data is None or data['highscore'] < int(score):
		Database.score_db().update_one({"players": players, "level": level}, {
			'$set':{"highscore": int(score)}
		}, upsert=True)

	top10 = Database.score_db().find({"level":level},projection={'_id': False}).sort("highscore", DESCENDING)[:10]

	data_for_client = list(
		map( lambda record: {"players": json.dumps(record['players']), "score": record['highscore']}, top10)
	)

	return json.dumps(data_for_client)

@app.route('/IsFinishedTutorial', methods=['POST'])
def is_finished_tutorial():
	steamid = request.form.get('steamid')
	if steamid is None:
		abort(502)

	player = Database.player_db().find_one({'steamid': steamid})
	if player is None:
		return '0'

	if player.get('FinishedTutorial') == True:
		return '1'

	return '0'

@app.route('/SetFinishedTutorial', methods=['POST'])
def set_finished_tutorial():
	steamid = request.form.get('steamid')
	if steamid is None:
		abort(502)
	
	Database.player_db().update({'steamid': steamid}, {'$set':{"FinishedTutorial": True, "JoinTime": datetime.datetime.now()}}, upsert = True)
	
	return 'ok'

@app.route('/SaveLanguage', methods=['POST'])
def save_language():
	language = request.form.get("language")
	steamid = request.form.get("steamid")
	if steamid is None:
		abort(502)

	Database.player_db().update({'steamid': steamid}, {'$set':{"Language": language}}, upsert = True)
	
	return "ok"

@app.route('/ShowLanguageStastics', methods=['GET'])
def show_language_stastics():
	players = Database.player_db().find()
	stast = {}
	for player in players:
		if not player.get("Language") is None:
			lang = player.get("Language")
			if stast.get(lang) is None:
				stast[lang] = 0
			stast[lang] += 1

	return "<br>".join(map(lambda x: x + ":  " + str(stast[x]), stast))

if __name__ == '__main__':
	app.run()
