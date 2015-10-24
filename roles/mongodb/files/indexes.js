use prod
db.draws.createIndex({'creation_time':1})
db.draws.createIndex({'owner':1})
db.chats.createIndex({"entries.creation_time":1}, { expireAfterSeconds: 60 * 60 * 24 * 30 } )
db.draws.createIndex({"creation_time":1}, { expireAfterSeconds: 60 * 60 * 24 * 30 * 12 } )
