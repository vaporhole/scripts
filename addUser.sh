#!/usr/bin/env bash
#####################################################################
# Criação de usuários no clube UnderHole
# Autor: Slackjeff
# Criação: 23/08/2023
#####################################################################

# Pegando dados
read -ep "Usuario: " user
read -ep "Chave: " sshKey

# Adicionando usuário
password=$(echo "$RANDOM" | md5sum | cut -d '-' -f 1)
useradd -s /bin/bash -m $user -p $(perl -e 'print crypt($ARGV[0], "password")' "$password")

# Montando estrutura para autorização da chave SSH.
mkdir -vp /home/${user}/.ssh && > /home/${user}/.ssh/authorized_keys
chmod -v 700 /home/${user}/.ssh && chmod 600 /home/${user}/.ssh/authorized_keys
echo "$sshKey" >> /home/${user}/.ssh/authorized_keys

# Criação public_html
mkdir -v /home/${user}/public_html
chmod -v 755 /home/${user}/public_html
echo "<h1>Ola Mundo.</h1>" > /home/${user}/public_html/index.html
chown -vR ${user}:${user} /home/${user}/

# Criação de arquivos
for x in '.plan' '.project'; do
    touch /home/${user}/${x}
    chown ${user}:${user} /home/${user}/${x}
done

# Cota de 100 mb por usuario
setquota -u $user 100M 120M 0 0 /

##### E-MAIL
cat <<EOF > /home/${user}/.muttrc
# About Me
set from = "$user@vaporhole.xyz"
set realname = "$user"

# My credentials
set smtp_url = "smtp://$user@vaporhole.xyz@mail.vaporhole.xyz:587"
set smtp_pass = ""
set imap_user = "$user@vaporhole.xyz"
set imap_pass = ""

# My mailboxes
set folder = "imaps://mail.vaporhole.xyz:993"
set spoolfile = "+INBOX"


# Where to put the stuff
set header_cache = "~/.mutt/cache/headers"
set message_cachedir = "~/.mutt/cache/bodies"
set certificate_file = "~/.mutt/certificates"

# Etc
set mail_check = 10
set timeout = 10
set move = no
set imap_keepalive = 900
set sort = threads
set editor = "nano"
set signature="~/.signature"
set arrow_cursor

# Colors
color hdrdefault cyan           default       # Make headers cyan
color quoted     green          default       # Quoted
color signature  red            default       # Red signatures
color indicator  brightblack    cyan                  # Indicator line black on cyan
color attachment magenta        default       # Attachments magenta
color error      brightred      default       # Make errors visible
color status     brightyellow   blue              # Make Status line bright yellow
color tree   green  default                   # Threads green
color normal     white  default               # Default white
color message    brightyellow   default               # Not sure what this one is....
color header     brightyellow   default ^(Subject)    # Yes. Yellow subject line. I like it like that.
color header     brightcyan     default  "^cc:"

color index     brightyellow    default "~N"    # New Messages are brighter
color index     brightyellow    default "~U"    # Set Unread meassager same as ~N
color index     brightred   default "~F"    # These are important messages
color index     cyan        default "~Q"    # Messages i replied to
color index     brightwhite default "~G"    # PGP Encrypted Message
color index     brightwhite default "~g"    # PGP Signed Message
color index     red         default "~D"    # Deleted Messages


# Highlights inside the body of a message.
color body  brightwhite     default "(http|https|ftp|news|telnet|finger)://[^ \">\t\r\n]*"
color body  brightwhite     default "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
color body  brightwhite     default "news:[^ \">\t\r\n]*"
color body  brightgreen     default "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"
color body  brightblue      default "<[Gg]>"               # <g>
color body  brightblue      default "<[Bb][Gg]>"           # <bg>
color body  brightblue      default " [;:]-*[)>(<|]"       # :-) etc...
color body  brightyellow    default "\\*[A-Za-z]+\\*"      # *Bold* text.
EOF

chown -v ${user}:${user} /home/${user}/.muttrc
chmod -v 700 /home/${user}/.muttrc
echo "------> .muttrc configurado [OK]"

# Criando usuario no gitea.
su -c "gitea admin user create --username $user --password $password --email ${user}@vaporhole.xyz --config /etc/gitea/app.ini" -m gitea
echo "------> Usuário no gitea criado [OK]"

echo
echo "--------------------------------------------------------------"
echo "Você agora faz parte do vaporHole clube. Seja bem vindo."
echo "Sua conta shell esta disponivel..."
echo
echo "Seu Username é : $user"
echo "Seu Password   : $password"
echo
echo "Você pode conectar no sevidor com o comando abaixo:"
echo "ssh -p 5339 ${user}@vaporhole.xyz"
echo
echo "Lembre-se de trocar o seu password temporário ao conectar com "
echo "o comando 'passwd'"
echo
echo "No seu diretório inicial, você encontrará um diretório chamado"
echo "public_html. Lá é aonde voce deve adicionar seu website."
echo "sua url pública é: https://vaporhole.xyz/~$user"
echo
echo "Caso queira modificar seu gopherhole, ele esta presente tbm"
echo "no seu home em public_gopher."
echo "Sua url pública é: gopher://vaporhole.xyz/1/$user"
echo
echo "Acesse o gitea em: https://git.vaporhole.xyz e entre com seu"
echo "username: $user e senha criado acima! Não esqueça de trocar."
echo
echo "Seu e-mail é: ${user}@vaporhole.xyz"
echo "e acessivel com a senha que você configurou para seu usuario."
echo "Para configurar por favor leia a documentação aqui:"
echo "https://vaporhole.xyz/ajuda/"
echo "--------------------------------------------------------------"
echo
echo
