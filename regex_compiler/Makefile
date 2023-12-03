APP = regex_compiler
CC = gcc
CFLAGS += -I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/include/sw -I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/include/hw -I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/include -I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/oniguruma/src \
		 -Wl,-rpath=/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile -L/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile -lxfcompile -Wl,-rpath=/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/lib -L/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/lib -lonig
# -Wl,-rpath=/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile -L/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile -lxfcompile -Wl,-rpath=/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/lib -L/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/lib -lonig
# -g -L/lib -lxfcompile -lonig \
-I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/include/sw \
-I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/include \
# -L/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile -lxfcompile \
-L/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/lib -lonig \
-I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/oniguruma/src \
# -I/tools/Xilinx_2021_2/Vitis/2021.2/ide/electron-app/lnx64/resources/app/node_modules/oniguruma/deps/onig/ \
# -lonig -v

all: $(APP)

$(APP): regex_compiler.c
	$(CC) -o regex_compiler regex_compiler.c $(CFLAGS)

clean:
	rm -f *.o $(APP)

# /home/jiaqil6/Vitis_Libraries/data_analytics/L1/src/sw/xf_re_compile.c
# gcc -shared -o /home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/libxfcompile.so /home/jiaqil6/Vitis_Libraries/data_analytics/L1/src/sw/xf_re_compile.c -g -Wall -Werror -fpic -std=c99 -gdwarf-2 \
#         -I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/include/sw -I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/oniguruma/src -I/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/include \
#         -L/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/lib -lonig
