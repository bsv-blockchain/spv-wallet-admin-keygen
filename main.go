// Package main generates xpub and xpriv key files for SPV wallet administration.
package main

import (
	"fmt"
	"os"

	"github.com/bsv-blockchain/spv-wallet-admin-keygen/keygen"
)

func main() {
	kp, err := keygen.Generate()
	if err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if err = kp.WriteToFiles("xpub_key.txt", "xprv_key.txt"); err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
