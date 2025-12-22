// Package keygen provides key generation functionality for SPV wallet administration.
package keygen

import (
	"fmt"
	"os"

	"github.com/bsv-blockchain/spv-wallet-go-client/walletkeys"
)

// KeyPair holds generated xpub and xpriv keys.
type KeyPair struct {
	xpub  string
	xpriv string
}

// Generate creates a new key pair.
func Generate() (*KeyPair, error) {
	keys, err := walletkeys.RandomKeys()
	if err != nil {
		return nil, fmt.Errorf("failed to generate keys: %w", err)
	}

	return &KeyPair{
		xpub:  keys.XPub(),
		xpriv: keys.XPriv(),
	}, nil
}

// XPub returns the extended public key.
func (kp *KeyPair) XPub() string {
	return kp.xpub
}

// XPriv returns the extended private key.
func (kp *KeyPair) XPriv() string {
	return kp.xpriv
}

// WriteToFiles writes the key pair to the specified file paths.
func (kp *KeyPair) WriteToFiles(xpubPath, xprivPath string) error {
	if err := writeFile(xpubPath, kp.xpub); err != nil {
		return fmt.Errorf("failed to write xpub key: %w", err)
	}

	if err := writeFile(xprivPath, kp.xpriv); err != nil {
		return fmt.Errorf("failed to write xpriv key: %w", err)
	}

	return nil
}

func writeFile(path, content string) error {
	f, err := os.Create(path) //nolint:gosec // path is controlled by caller
	if err != nil {
		return err
	}
	defer func() { _ = f.Close() }()

	_, err = f.WriteString(content)
	return err
}
