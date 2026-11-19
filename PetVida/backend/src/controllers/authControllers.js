
const db = require('../config/configDB');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Login do funcionário
async function login(req, res) {
    try {
        const { email, senha } = req.body;

        // Verificar se os campos foram preenchidos
        if (!email || !senha) {
            return res.status(400).json({
                mensagem: 'Informe o e-mail e a senha. 🤠 '
            });
        }

        // Buscar funcionário pelo e-mail
        const [funcionarios] = await db.query(
            'SELECT * FROM funcionario WHERE email = ?',
            [email]
        );

        // Verificar se o funcionário existe
        if (funcionarios.length === 0) {
            return res.status(401).json({
                mensagem: 'E-mail ou senha inválidos. 😏'
            });
        }

        const funcionario = funcionarios[0];

        // Verificar se está ativo
        if (funcionario.ativo !== 1) {
            return res.status(403).json({
                mensagem: 'Funcionário inativo.'
            });
        }

        // Comparar senha digitada com senha criptografada
        const senhaValida = await bcrypt.compare(
            senha,
            funcionario.senha_hash
        );

        if (!senhaValida) {
            return res.status(401).json({
                mensagem: 'E-mail ou senha inválidos.'
            });
        }

        // Gerar token de autenticação
        const token = jwt.sign(
            {
                id: funcionario.id_funcionario,
                perfil: funcionario.perfil
            },
            process.env.JWT_SECRET,
            {
                expiresIn: '1h'
            }
        );

        // Retornar os dados do funcionário
        return res.status(200).json({
            mensagem: 'Login realizado com sucesso! 💛🧡',
            token,
            funcionario: {
                id: funcionario.id_funcionario,
                nome: funcionario.nome,
                email: funcionario.email,
                perfil: funcionario.perfil
            }
        });

    } catch (erro) {
        console.error('Erro no login:', erro);

        return res.status(500).json({
            mensagem: 'Erro a entrar no servidor'
        });
    }
}

module.exports = { login };
