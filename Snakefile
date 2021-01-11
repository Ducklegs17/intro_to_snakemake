#ASSEMBLIES = ["canu_hifi11_25x",
#	"flye_clr_50x",
#	"flye_hifi24_25x",
#	"raven_clr_50x",
#	"canu_hifi24_25x",
#	"flye_hifi11_25x",
#	"hifiasm_hifi24_25x",
#	"wtdbg2_clr_50x"]


localrules: 

rule all:
	input:
		"1_graphs/graph.txt",

rule quast_raw:
	input:
		"0_assemblies/canu_hifi11_25x.fa",
	output:
		"test/report.tsv",
	threads:
		6
	singularity:
		"docker://quay.io/biocontainers/quast:5.0.2--1"
	shell:
		"""
		quast {input} --threads {threads} -o test
		"""


