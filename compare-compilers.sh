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

cd cmdstan; make -j4 examples/bernoulli/bernoulli; ./bin/stanc --version; cd ..
python ./runPerformanceTests.py --overwrite-golds $1

for i in performance.*; do
    mv $i "reference_${i}"
done

cp "$2" cmdstan/bin/stanc # relies on cmdstan Makefile to know to update the models once stanc has been updated.
cmdstan/bin/stanc --version
python ./runPerformanceTests.py --check-golds-exact 1e-8 $1 --scorch-earth && ./comparePerformance.py "reference_performance.csv" performance.csv csv
