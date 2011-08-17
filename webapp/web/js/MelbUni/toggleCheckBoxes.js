function checkAll(field)
{
	for (i = 0; i < field.length; i++)
	{
		field[i].checked = true ;
	}
}

function unCheckAll(field)
{
	for (i = 0; i < field.length; i++)
	{
		field[i].checked = false ;
	}
}

function checkBox(nameStr)
{
	/*document.getElementById('inferredStatements'+count).removeAttribute('disabled');*/
    ('input[name=' + nameStr + ']').removeAttribute('disabled');
}

function unCheckBox(nameStr)
{
	/*document.getElementById('inferredStatements'+count).disabled='true';*/
    ('input[name=' + nameStr + ']').disabled='true';
}
