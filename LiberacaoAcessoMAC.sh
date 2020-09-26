#!/bin/bash
# Criado: Tácio de Jesus Andrade - tacio@multiti.com.br
# Data: 26-09-2020
# Função: Script que monta um firewall que bloqueia o acesso ao servidor de máquinas não cadastradas
# Informações: O arquivo /var/PCs.txt devem ter o padrão abaixo, removendo-se a primeira #
# # TACIO-NOTEBOOK
# 5C-C9-D3-A7-47-A5
# # MARIA-PC
# 5C:C9:D3:A7:47:A6

########################### Funções ###########################

libera_mac (){

	PCs=`cat /var/PCs.txt | sed 's/-/:/g' | egrep -v "^[#;]" `;

	for mac in $PCs ; do
		# Libera o acesso apenas aos MACs cadastrados
		iptables -t filter -A INPUT -m mac --mac-source $mac -j ACCEPT
	done

	# Bloqueia MACs não cadastrados
	iptables -t filter -A INPUT -m state --state ESTABLISHED -j ACCEPT

	iptables -t filter -A INPUT -j DROP

}

###############################################################

# Verifica se o usuário é root
if [ "$(id -u)" != "0" ]; then
    echo "Voce deve executar este script como root!"
    exit 1
fi

case "$1" in
	start)
		echo "Ativando as regras, apenas os MACs cadastrados acessarão o servidor!"
		libera_mac
		echo "Regras ativadas! Agora somente os MACs cadastrados acessarão o servidor!"
		;;
	stop)
		echo "Limpando as regras, qualquer computador poderá acessar o servidor!"
		iptables -F
		echo "Regras Removidas! Agora qualquer computador poderá acessar o servidor!"
		;;
	restart)
		$0 stop
		$0 start
		;;
	*)
		echo "Comando não reconhecido, utilize uma das opções: $0 start ou $0 stop ou $0 restart"
		exit 1
	;;
esac
