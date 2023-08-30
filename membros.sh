#!/bin/sh
#####################################################################
# Programa verificador de membros do vaporHole
# Slackjeff - slackjeff@vaporhole.xyz
#
# !NOTA!
# NÃO botei a grande parte do código html em um heredocument
# e sim em echos para ter umma maior flexibilidade no código
# e no shell para poder implementar futuras features.
#####################################################################

#============== Variaveis
url="https://vaporhole.xyz"
doc="/var/www/html/membros.html"

#============== Inicio
html(){
cat <<EOF > $doc
    <!Doctype html>
        <head>
            <meta charset="utf-8">
            <title>Membros - VaporHole</title>
            <link rel="stylesheet" href="/style.css">
        </head>
        <body>
EOF
}

# Chamando funcao
html

# Conteudo inicia da página
echo "<h1>VaporHole Clube - Membros</h1>" >> $doc
echo "<h2>última atualização: $(date)</h2>" >> $doc
echo "<p>Lista de nossos membros do clube VaporHole, usuários com @ na frente do nome são administradores.</p>" >> $doc

# Entrando no diretorio para inicair contagem
cd /home/

# Abrindo tag da lista
echo "<ul>" >> $doc
# Verificando os usuarios para por na lista os nomes
for user in *; do
    if id $user | grep -q "1009(mestre)"; then
        echo "<a href="$url/~$user"><li>@$user</li></a>" >> $doc
        continue
    fi
    if [ $user = "ergo" ]; then
        continue
    fi
    echo "<a href="$url/~$user"><li>$user</li></a>" >> $doc
done
# Fechando tag da lista
echo "</ul>" >> $doc

# Verificando total de usuarios
# Não é a melhor forma com ls. forem para economizar um loop! +)
total=$(ls /home/ | wc -l)
echo "<h2>No momento temos '$total' membros cadastrados.</h2>" >> $doc

# Fechando tags html
echo "</body>" >> $doc
echo "</html>" >> $doc
