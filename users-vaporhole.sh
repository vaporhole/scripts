#!/bin/bash
#================HEADER==============================================|
# Autor
# Jefferson 'Slackjeff' Rocha <root@slackjeff.com.br>
#
# O que este programa faz?
# Checagem em /home/ de usuários federados que existem no sistema.
#====================================================================|

. /etc/profile # PATH for cron

#============================== VARS
name="Usuários Federados"
archive_html='/var/www/htdocs/users.html'
link='http://vaporhole.duckdns.org/'

#============================== FUNCS
_START_HTML() # Inicializando html
{
    hour="$(/bin/date)"
    cat <<EOF >> "$archive_html"
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>$name</title>
    <meta charset="utf-8">
    <style>
        body{background-color: #191919; color: #00ffba; font-size: 1.2em;}
        a{color: white;}
    </style>
</head>
<body>
    <a href="index.html">Retornar</a>
    <h1 align=center>Usuários Federados</h1>
    <h4 align=center>Página atualizada de 1 em 1 minuto, última atualização: $hour</h4>
    <ul>
EOF
}

_BODY_HTML() # Corpo da página HTML, as listas.
{
    local receive_user="$1"
    cat <<EOF>> "$archive_html"
<li><a href=${link}~${receive_user}>~$receive_user</a></li>
EOF
}

_END_HTML() # Finalizando página html
{
    cat <<EOF>> "$archive_html"
</ul>
</body>
</html>
EOF
}

#============================== INICIO
[[ -e "$archive_html" ]] && /bin/rm "$archive_html"
_START_HTML # Inicializando página HTML

for check_users in /home/*; do
    if [[ "$check_users" =~ .*ftp ]]; then
        continue
    else
        check_users="${check_users//\/home\//}" # Cut /home/
        _BODY_HTML "$check_users" # send user for function
    fi
done

_END_HTML # Finalizando página HTML

