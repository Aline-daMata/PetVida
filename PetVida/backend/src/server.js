const app = require('./app');
const db = require('./config/configDB');

// Porta do servidor
const PORT = process.env.PORT || 3000;

// Testando conexão com MySQL
db.getConnection()
    .then((connection) => {
        console.log('Conexão com MySQL realizada 💛💛');

        connection.release();

        // Iniciando servidor
        app.listen(PORT, () => {
            console.log(`Servidor rodando em http://localhost:${PORT}`);
        });
    })
    .catch((erro) => {
        console.error('Erro ao conectar com MySQL:', erro.message);
    });