# check if model is inactive
if [[ $(aws sagemaker list-models | jq ".Models[0].ModelName") == null ]]; then
    echo "model inactive. run './summarize deploy' to deploy model and activate the query functionality"
    exit 1
fi

# check if corpus is too long
if [[ $(wc -m corpus.txt | cut -d' ' -f1) -gt 2155 ]]; then
    echo "corpus is too long. please shorten to 1025 words or less"
    echo "current corpus length: $(wc -w corpus.txt | cut -d' ' -f1)"
    exit 1
fi

# source check_active to ensure we have endpoint & model names in environment
export endpt=$(aws sagemaker list-endpoints | jq ".Endpoints[0].EndpointName")

# pull endpoint name & clean for invoke command
endpt_temp=$(echo $endpt | tr -d '"') # remove quotes for sagemaker invocation

# run to_json to clean up user input
python bash_cli/to_json.py

echo "invoking endpoint..."
aws sagemaker-runtime invoke-endpoint \
    --endpoint-name $endpt_temp \
    --body file://bash_cli/corpus.json \
    --content-type application/json output_file.txt

echo -e "finished, results in output_file.txt\n"
echo "result: "
./src/print_output.sh




echo -e "\nremember to run './summarize remove' to avoid being charged for unused resources"
echo "replace text in corpus.txt to run a new query"

exit 0

#inspect_args # add back if you want to add args or flags
