./stress/lock-a-lot.out: ./stress/lock-a-lot.c
	gcc $^ -o $@

fmt:
	cd ./stress && clang-format -style=file -i ./lock-a-lot.c

.PHONY: fmt
