function tf_fmt() {
  # TODO: fix it, it still works on .terraform...
  find . -type f \( -name "*.tf" -or -name "*.tfvars" -and ! -path "./.terraform/*" \) -exec terraform fmt {} \;
}