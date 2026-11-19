// =============================================================
// authMiddleware.js - os "seguranças" das rotas
//
// verificarToken: confere se a pessoa está logada (token válido)
//                 e se o funcionário continua ativo (RN06).
// permitir:       confere se o perfil tem permissão para a rota
//                 (matriz de permissões da documentação técnica).
// =============================================================

const jwt = require('jsonwebtoken');
const db = require('../config/configDB');

// ---------- 1. Está logado? ----------
async function verificarToken(req, res, next) {
    // O front manda o cabeçalho assim:  Authorization: Bearer eyJhbGci...
    const header = req.headers.authorization;
    if (!header) {
        return res.status(401).json({ msg: 'Sem token! Faça login.' });
    }

    const [tipo, token] = header.split(' ');      // ["Bearer", "eyJhbGci..."]
    if (tipo !== 'Bearer' || !token) {
        return res.status(401).json({ msg: 'Formato do token inválido. Use: Bearer <token>' });
    }

    let decoded;
    try {
        decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
        return res.status(401).json({ msg: 'Token inválido ou expirado. Faça login novamente.' });
    }

    try {
        // RN06: um funcionário desativado não usa mais o sistema,
        // mesmo que ainda tenha um token válido de antes.
        const [rows] = await db.query(
            'SELECT ativo FROM funcionario WHERE id_funcionario = ?',
            [decoded.id]
        );
        if (rows.length === 0 || rows[0].ativo !== 1) {
            return res.status(401).json({ msg: 'Acesso desativado. Procure a gerência.' });
        }
    } catch (error) {
        console.error(error);
        return res.status(500).json({ msg: 'Erro interno no servidor.' });
    }

    // Guarda quem está logado para os próximos passos usarem
    req.usuario = { id: decoded.id, perfil: decoded.perfil };
    return next();
}

// ---------- 2. Tem permissão? ----------
// Uso na rota: permitir('gerente')  ou  permitir('recepcionista', 'gerente')
function permitir(...perfis) {
    return (req, res, next) => {
        if (!perfis.includes(req.usuario.perfil)) {
            return res.status(403).json({ msg: 'Seu perfil não tem permissão para esta ação.' });
        }
        return next();
    };
}

module.exports = { verificarToken, permitir };
