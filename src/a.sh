#!/bin/bash
#set -Ceu
#-----------------------------------------------------------------------------
# Bashの宣言・スコープ・ライフサイクル
# 作成日時: 2019-04-08T11:14:06+0900
#-----------------------------------------------------------------------------
Env() {
	export K=V
	export A=(A B C)
	#export AA=([a]=1 [b]=2) # declare -ax AA=([0]="2") となる
	#`export declare -Ag AA=([A]=1 [B]=2)`はエラーになる(`bash: export: `-Ag': 有効な識別子ではありません`)
	#`declare -A`では関数外`set`に表示されない。`${#AA[@]}`などの参照も不可。`-g`がないとGlobalにならずLocalになり本関数内で死ぬ。
	declare -Ag AA=([A]=1 [B]=2)
	export AA
	F() { echo MyFunc; }
	export F
	# exportした配列は`env`,`printenv`だと出ないが`declare -x`,`set`だと出る
	set | grep '^K='
	set | grep '^A='
	set | grep '^AA='
	set | grep '^F ()'
	echo "$K"
	echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
	for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo '';
	echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
	for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo '';
	F
}
Global() {
	K=V
	A=(A B C)
	declare -Ag AA=([A]=1 [B]=2)
	F() { echo MyFunc; }
	set | grep '^K='
	set | grep '^A='
	set | grep '^AA='
	set | grep '^F ()'
	echo "$K"
	echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
	for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo '';
	echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
	for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo '';
}
Local() {
	local K=V
	local A=(A B C)
	declare -A AA=([A]=1 [B]=2)
	# 予期しないトークン `(' 周辺に構文エラーがあります
	#local F() { echo MyFunc; }
	# 予期しないトークン `(' 周辺に構文エラーがあります
	#declare F() { echo MyFunc; };
	# Local化されずGlobalになる...
	F() { echo MyFunc; }
	# declareでローカル化しようとしたが効かず
	declare F
	set | grep '^K='
	set | grep '^A='
	set | grep '^AA='
	set | grep '^F ()'
	echo "$K"
	echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
	for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo '';
	echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
	for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo '';
}
SubProcEnv() {
	(
		export K=V
		export A=(A B C)
		declare -Ag AA=([A]=1 [B]=2)
		export AA
		F() { echo MyFunc; }
	)
	set | grep '^K='
	set | grep '^A='
	set | grep '^AA='
	set | grep '^F ()'
	[ -n "$(set | grep '^K=')" ] && echo "$K"
	[ -n "$(set | grep '^A=')" ] && echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
	[ -n "$(set | grep '^A=')" ] && { for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo ''; }
	[ -n "$(set | grep '^AA=')" ] && echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
	[ -n "$(set | grep '^AA=')" ] && { for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo ''; }
}
SubProcGlobal() {
	(
		K=V
		A=(A B C)
		declare -Ag AA=([A]=1 [B]=2)
		F() { echo MyFunc; }
	)
	set | grep '^K='
	set | grep '^A='
	set | grep '^AA='
	set | grep '^F ()'
	[ -n "$(set | grep '^K=')" ] && echo "$K"
	[ -n "$(set | grep '^A=')" ] && echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
	[ -n "$(set | grep '^A=')" ] && { for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo ''; }
	[ -n "$(set | grep '^AA=')" ] && echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
	[ -n "$(set | grep '^AA=')" ] && { for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo ''; }
}
Group() {
	{
		K=V
		A=(A B C)
		declare -Ag AA=([A]=1 [B]=2)
		F() { echo MyFunc; }
	}
	set | grep '^K='
	set | grep '^A='
	set | grep '^AA='
	set | grep '^F ()'
	[ -n "$(set | grep '^K=')" ] && echo "$K"
	[ -n "$(set | grep '^A=')" ] && echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
	[ -n "$(set | grep '^A=')" ] && { for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo ''; }
	[ -n "$(set | grep '^AA=')" ] && echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
	[ -n "$(set | grep '^AA=')" ] && { for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo ''; }
}
# ------------------------------------------------------------------
# Readonlyにするとunsetできなくなる！　困るのでサブプロセス内でやる。
# ------------------------------------------------------------------
Global_Readonly() {
	(
		readonly K=V
		readonly A=(A B C)
		# readonly: `-A': 有効な識別子ではありません
		#readonly declare -A AA=([A]=1 [B]=2)
		declare -Agr AA=([A]=1 [B]=2)

		set | grep '^K='
		set | grep '^A='
		set | grep '^AA='
		echo "$K"
		echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
		for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo '';
		echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
		for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo '';
	)
	(
		declare -gr K=V
		declare -agr A=(A B C)
		declare -Agr AA=([A]=1 [B]=2)

		set | grep '^K='
		set | grep '^A='
		set | grep '^AA='
		echo "$K"
		echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
		for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo '';
		echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
		for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo '';
	)
}
Local_Readonly() {
	(
		OF1() {
			local -r K=V
			local -r A=(A B C)
			declare -A AA=([A]=1 [B]=2)
			F() { echo MyFunc; }
		}
		OF2() {
			declare -r K=V
			declare -ar A=(A B C)
			declare -Ar AA=([A]=1 [B]=2)
			F() { echo MyFunc; }
		}
		set | grep '^K='
		set | grep '^A='
		set | grep '^AA='
		set | grep '^F ()'
		[ -n "$(set | grep '^K=')" ] && echo "$K"
		[ -n "$(set | grep '^A=')" ] && echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
		[ -n "$(set | grep '^A=')" ] && { for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo ''; }
		[ -n "$(set | grep '^AA=')" ] && echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
		[ -n "$(set | grep '^AA=')" ] && { for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo ''; }
	)
}
# テキストをコードとして実行する`. <(echo $Code)`。ファイルなら`. file.sh`
Stream() {
	(
		Code=$(cat <<- 'EOS'
			K=V
			A=(A B C)
			declare -A AA=([A]=1 [B]=2)
			F() { echo MyFunc; }
		EOS
		)
		. <(echo "$Code")
		set | grep '^K='
		set | grep '^A='
		set | grep '^AA='
		set | grep '^F ()'
		echo "$K"
		echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
		for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo '';
		echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
		for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo '';
		F
	)
}
StreamSubProc() {
	(
		Code=$(cat <<- 'EOS'
			K=V
			A=(A B C)
			declare -A AA=([A]=1 [B]=2)
			F() { echo MyFunc; }
		EOS
		)
		bash -c "$Code"
		[ -n "$(set | grep '^K=')" ] && echo "$K"
		[ -n "$(set | grep '^A=')" ] && echo "A { num: ${#A[@]}, keys: ${!A[@]} }"
		[ -n "$(set | grep '^A=')" ] && { for ((i=0; i<${#A[@]}; i++)); do echo -n "${A[$i]} "; done; echo ''; }
		[ -n "$(set | grep '^AA=')" ] && echo "AA { num: ${#AA[@]}, keys: ${!AA[@]} }"
		[ -n "$(set | grep '^AA=')" ] && { for key in ${!AA[@]}; do echo -n "${AA[$key]} "; done; echo ''; }
		[ -n "$(set | grep '^F ()')" ] && F
	)
}

Run() {
	Funcs='Env Global Local SubProcEnv SubProcGlobal Group Global_Readonly Local_Readonly Stream StreamSubProc'
	for func in $Funcs; do
		echo "========== ${func} =========="
		unset K A AA F
		eval $(echo $func)
		echo "----- global ref -----"
		set | grep '^K='
		set | grep '^A='
		set | grep '^AA='
		set | grep '^F ()'
	done
	unset K A AA F
}
Run

