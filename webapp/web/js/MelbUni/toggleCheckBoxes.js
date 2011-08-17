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
    $('input[name=' + nameStr + ']').removeAttr('disabled');
}

function unCheckBox(nameStr)
{
    $('input[name=' + nameStr + ']').attr('disabled', 'disabled');
}
