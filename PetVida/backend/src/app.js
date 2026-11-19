
const express = require('express');
const db = require('./config/configDB');
const authRoutes = require('./routes/authRoutes');

const app = express();

// Permite receber dados JSON
app.use(express.json());

// Rota inicial
app.get('/', (req, res) => {
    res.status(200).json({
        mensagem: ' PetVidas funcionando! 🐶'
    });
});

// Rotas de autenticação
app.use('/auth', authRoutes);


// Rota GET - Listar funcionários
app.get('/funcionarios', async (req, res) => {
    try {
        const [funcionarios] = await db.query(
            'SELECT * FROM funcionario'
        );

        res.status(200).json(funcionarios);

    } catch (erro) {
        res.status(500).json({
            mensagem: 'Erro ao consultar funcionários.'
        });
    }
});

module.exports = app;
