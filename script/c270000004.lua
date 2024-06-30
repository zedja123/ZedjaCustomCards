--Prismiant Tactical Revenge
function c270000004.initial_effect(c)
	-- Negate effect and shuffle into Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(negcon)
	e1:SetTarget(negtg)
	e1:SetOperation(negop)
	c:RegisterEffect(e1)
end

function cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf10) and c:IsType(TYPE_SYNCHRO)
end

function negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function negop(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end