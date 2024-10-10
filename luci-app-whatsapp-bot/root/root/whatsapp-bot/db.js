const mysql = require('mysql');

const db = mysql.createConnection({
    host: '127.0.0.1',
    user: 'radius',
    password: 'radius',
    database: 'radius'
});
exports.db = db;
db.connect((err) => {
    if (err) {
        return;
    }
});
