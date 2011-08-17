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

function checkBox(idStr)
{
    $("#" + idStr).removeAttr('disabled');
}

function unCheckBox(idStr)
{
    $("#" + idStr).attr('disabled', 'disabled');
}
