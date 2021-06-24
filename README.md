# PG_Cade_Anvisa Docker

Programa de gestão do Cade/Anvisa em container docker.


## Instruções

1. Instale o [Docker for Windows](https://docs.docker.com/docker-for-windows/install/)
2. Configure as variáveis de ambiente do sistema no arquivo **pg_cade.env**.

```sh
# Se você quiser apenas testar, utilize Desenvolvimento
AMBIENTE=Producao
DEFAULTLOGGERNAME=nomeDoLogger
GRAVAREMAILEMARQUIVO=false
CAMINHOARQUIVOEMAIL=C:\emails
MODIFICARASSUNTOCONFORMEAMBIENTE=true
ADFSREALM=https://localhost/pgd/
ADFSMETADATA=https://adfs-h.cgu.gov.br/federationmetadata/2007-06/federationmetadata.xml
ADFSREPLY=
WTREALM=
SIGRHAPI=https://localhost/sigrhapi/
URLPGD=https://localhost/pgd/
DIRARQUIVOS=C:\arquivos
HABILITARTRATAMENTOBANCOREPLICADO=false
# String de conexão do seu banco de dados
PGDCONNECTIONSTRING=
DEBUG=false
NIVEISLOG=Error,Warn,Info,Debug
SMTPFROM=
SMTPHOST=
SMTPPORT=25
USEDEFAULTCREDENTIALS=true
SMTPUSERNAME=
SMTPPASSWORD=
LDAPIP=
LDAPPORT=389
# Credencial de acesso ao ldap
NETWORKCREDENTIALLDAP=cn={0},dc=com,dc=br
# Filtro para buscar um usuário no LDAP, por padrão utiliza apenas o campo sAMAccountName.
LDAPQUERYFILTER=(sAMAccountName={0})
```

Caso precise alterar alguma variável de ambiente terá que recriar o container.

3. Faça o build da imagem usando o seguinte comando
```sh
 docker build --rm -t pg-cade:latest .
```
4. Crie pastas para persistir os dados salvos entre o container e o Windows
```powershell
 mkdir %HOMEDRIVE%\PGCadeMMA\emails
 mkdir %HOMEDRIVE%\PGCadeMMA\arquivos
```
5. Crie o container utilizando a porta **9111** ou outra se preferir. ie -p 80:80 (utiliza a porta 80)
   tecle enter ao final.
```
 docker run -d -p 9111:80 -v %HOMEDRIVE%\PGCadeMMA\emails:C:\emails ^
                          -v %HOMEDRIVE%\PGCadeMMA\arquivos:C:\arquivos ^
                         --name gestao_cade ^
                         --env-file pg_cade.env pg-cade
```

6. (Opcional) Atualize o ícone do sistema
```
 docker stop gestao_cade && docker cp C:\CAMINHO_DO_SEU_ICONE\favicon.ico gestao_cade:C:\inetpub\wwwroot\favicon.ico && docker start gestao_cade
```

7. Você pode verificar a implantação do sistema em  ```http://localhost:9111```


