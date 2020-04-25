usage() {
    echo "This won't clean anything, it will use whatever is in the cmdstan submodule even if it's dirty."
    echo "Pass the arguments to runPerformanceTests.py in quotes as the first argument."
    echo "Pass the alternative compiler binary path as the second argument."
}

if [ -z "$1" ] || [ -z "$2" ] ; then
    usage
    exit
fi

set -e -x

cp "$2" cmdstan/bin/stanc

#cd cmdstan; make -j4 examples/bernoulli/bernoulli; ./bin/stanc --version; cd ..

python ./runPerformanceTests.py --overwrite-golds $1
for i in performance.*; do
    mv $i "reference_${i}"
done

# 1e-5 is enough to account for mfa in almost all models
python ./runPerformanceTests.py --stancflags "\"--O 2\"" --check-golds-exact 1e1 $1 --scorch-earth && python ./comparePerformance.py "reference_performance.csv" performance.csv csv
#python ./runPerformanceTests.py --check-golds-exact 1e-5 $1 --scorch-earth && python ./comparePerformance.py "reference_performance.csv" performance.csv csv
