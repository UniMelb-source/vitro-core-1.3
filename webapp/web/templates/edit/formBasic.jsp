<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="editingForm">

<c:set var="colspan">
	<c:out value="${colspan}" default="3"/>
</c:set>

<c:set var="onSubmit">
   <c:out value="${formOnSubmit}" default="return true;"/>
</c:set>

<c:set var="action">
    <c:out value="${editAction}" default="doEdit"/>
</c:set>

<form id="editForm" name="editForm" action="${action}" method="post" onsubmit="${onSubmit}">
    <input type="hidden" name="_epoKey" value="${epoKey}" />

<div align="center">
<table cellpadding="4" cellspacing="2">
	<tr><th>
	<div class="entryFormHead">
		<h2>${title}</h2>
			<c:choose>
				<c:when test='${_action == "insert"}'>
					<h3>Creating New Record</h3>
				</c:when>
				<c:otherwise>
					<h3>Editing Existing Record</h3>
				</c:otherwise>
			</c:choose>
		<span class="entryFormHeadInstructions">(<sup>*</sup> Required Fields)</span>
	</div><!--entryFormHead-->
	</th></tr>
	
	<tr><td><span class="warning">${globalErrorMsg}</span></td></tr>
	
	<jsp:include page="${formJsp}"/>
	
	<tr class="editformcell">
		<td align="center">
			<c:choose>
				<c:when test='${_action == "insert"}'>
					<input id="primaryAction" type="submit" class="form-button" name="_insert" value="Create New Record"/>
				</c:when>
				<c:otherwise>		
    				<input id="primaryAction" type="submit" class="form-button" name="_update" value="Submit Changes"/>
                    <c:if test="${ ! (_cancelButtonDisabled == 'disabled') }">	
				        <input type="submit" class="form-button" name="_delete" onclick="return confirmDelete();" value="Delete"/>
                    </c:if>
				</c:otherwise>
			</c:choose>
			
			<input type="reset"  class="form-button" value="Reset"/>
			
            <c:choose>
                <c:when test="${!empty formOnCancel}">
                    <input type="submit" class="form-button" name="_cancel" onclick="${formOnCancel}" value="Cancel"/> 
                </c:when>
                <c:otherwise>
		            <input type="submit" class="form-button" name="_cancel" value="Cancel"/>
                </c:otherwise>
            </c:choose>
		</td>
	</tr>
</table>
</div><!--alignCenter-->

</form>

</div><!--editingform-->
