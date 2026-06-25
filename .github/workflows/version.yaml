  uses: actions/checkout@v2
    
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: 22

    - name: Verify Node.js Version
      run: node -v

    - name: Download cortexcli
      run: |
        set -x
        crtx_resp=$(curl "${CORTEX_API_URL}/public_api/v1/unified-cli/releases/download-link?os=linux&architecture=amd64" \
          -H "x-xdr-auth-id: ${CORTEX_API_KEY_ID}" \
          -H "Authorization: ${CORTEX_API_KEY}")
        crtx_url=$(echo $crtx_resp | jq -r ".signed_url")
        curl -o cortexcli $crtx_url
        chmod +x cortexcli
        ./cortexcli --version

    - name: Run Cortex CLI Code Scan
      run: |
        ./cortexcli \
          --version

    # ADDED STEP HERE
    - name: Clean up Cortex CLI
      if: always() 
      run: ./cortexcli clean
