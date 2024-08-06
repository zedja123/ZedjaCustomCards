-- Lavoisier Sphere Field
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Add 1 "Lavoisier" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	-- Negate opponent's card/effect activation in response to "Lavoisier" cards/effects
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

-- Activate: Add 1 "Lavoisier" monster from your Deck to your hand
function s.thfilter(c)
	return c:IsSetCard(0xf13) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Negate opponent's card/effect activation in response to "Lavoisier" cards/effects
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==1-tp and Duel.IsChainDisablable(ev)) or re:GetHandler():IsDisabled() then return false end
	local ch=Duel.GetCurrentChain(true)-1
	if ch>0 then
		local cplayer=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)
		local ceff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
		if cplayer==tp and ceff:GetHandler():IsSetCard(0xf13) and ceff:IsMonsterEffect() then
			return true
		end
	end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.NegateEffect(ev)
	end
end