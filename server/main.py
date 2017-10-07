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
		self.conn = MongoClient('localhost', 27017)

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

Database = database() # make connection pool to database

# for testing purpose
@app.route('/', methods=['GET'])
def index():
	return "server for darklord's feastivus"

@app.route('NewMatch', methods=['POST'])
def new_match():
	pass

@app.route('EndMatch', methods=['POST'])
def end_match():
	pass

if __name__ == '__main__':
	app.run(host='0.0.0.0', port=10010, debug=True)