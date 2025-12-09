package keygen

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestGenerate(t *testing.T) {
	kp, err := Generate()
	if err != nil {
		t.Fatalf("Generate() returned error: %v", err)
	}

	if kp.XPub() == "" {
		t.Error("XPub() returned empty string")
	}

	if kp.XPriv() == "" {
		t.Error("XPriv() returned empty string")
	}

	// xpub keys start with "xpub"
	if !strings.HasPrefix(kp.XPub(), "xpub") {
		t.Errorf("XPub() = %q, want prefix 'xpub'", kp.XPub())
	}

	// xpriv keys start with "xprv"
	if !strings.HasPrefix(kp.XPriv(), "xprv") {
		t.Errorf("XPriv() = %q, want prefix 'xprv'", kp.XPriv())
	}
}

func TestWriteToFiles(t *testing.T) {
	kp, err := Generate()
	if err != nil {
		t.Fatalf("Generate() returned error: %v", err)
	}

	tmpDir := t.TempDir()
	xpubPath := filepath.Join(tmpDir, "xpub_key.txt")
	xprivPath := filepath.Join(tmpDir, "xpriv_key.txt")

	err = kp.WriteToFiles(xpubPath, xprivPath)
	if err != nil {
		t.Fatalf("WriteToFiles() returned error: %v", err)
	}

	// Verify xpub file content
	xpubContent, err := os.ReadFile(xpubPath) //nolint:gosec // test file path
	if err != nil {
		t.Fatalf("failed to read xpub file: %v", err)
	}
	if string(xpubContent) != kp.XPub() {
		t.Errorf("xpub file content = %q, want %q", string(xpubContent), kp.XPub())
	}

	// Verify xpriv file content
	xprivContent, err := os.ReadFile(xprivPath) //nolint:gosec // test file path
	if err != nil {
		t.Fatalf("failed to read xpriv file: %v", err)
	}
	if string(xprivContent) != kp.XPriv() {
		t.Errorf("xpriv file content = %q, want %q", string(xprivContent), kp.XPriv())
	}
}

func TestWriteToFiles_InvalidPath(t *testing.T) {
	kp, err := Generate()
	if err != nil {
		t.Fatalf("Generate() returned error: %v", err)
	}

	// Try to write to an invalid path
	err = kp.WriteToFiles("/nonexistent/dir/xpub.txt", "/nonexistent/dir/xpriv.txt")
	if err == nil {
		t.Error("WriteToFiles() expected error for invalid path, got nil")
	}
}
