
const bcrypt = require('bcryptjs');

async function gerarSenha() {
    const senha = '123456789';

    const hash = await bcrypt.hash(senha, 10);

    console.log('Senha:', senha);
    console.log('Hash:', hash);
}

gerarSenha();
