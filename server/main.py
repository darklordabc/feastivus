# a simple server for darklord's feastivus game mode
# using python3, mongodb and flask
from flask import Flask, request, abort
from pymongo import MongoClient, DESCENDING
from bson import ObjectId
import json, math, time, datetime

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
		now = str(now.year) + str(now.month) 
		db = self.conn['feastivus_' + now]
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
		return self.conn['deals']

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

	Database.score_db().update_one({"players": players, "level": level}, {
		'$set':{"highscore": score}
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

	if player['FinishedTutorial'] == True:
		return '1'

	return '0'

@app.route('/SetFinishedTutorial', methods=['POST'])
def set_finished_tutorial():
	steamid = request.form.get('steamid')
	if steamid is None:
		abort(502)
	
	return 'ok'

if __name__ == '__main__':
	app.run(host='0.0.0.0', port=10010, debug=True)
