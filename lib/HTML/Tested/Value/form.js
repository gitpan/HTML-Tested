function validate(form, control, regexp) {
	if (form[control].value.search(regexp) == -1) {
		alert("problem with " + control);
		return false;
	} else
		return true;
}
