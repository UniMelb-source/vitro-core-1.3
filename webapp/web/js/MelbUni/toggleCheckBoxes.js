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

function checkBox(count)
{
	document.getElementById('inferredStatements'+count).removeAttribute('disabled');
}

function unCheckBox(count)
{
	document.getElementById('inferredStatements'+count).disabled='true';
}
