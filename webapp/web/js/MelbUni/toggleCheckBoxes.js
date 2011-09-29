function checkAll(field)
{
	for (i = 0; i < field.length; i++)
	{
		//field[i].checked = true ;
        if(field[i].checked == false)
        {
            field[i].click();
        }
	}
}

function unCheckAll(field)
{
	for (i = 0; i < field.length; i++)
	{
		//field[i].checked = false ;
        if(field[i].checked == true)
        {
            field[i].click();
        }
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
