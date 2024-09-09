--Build Rider - Hawk Gatling
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- Link Summon procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xf15),1,2)
	-- Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_EARTH)
	c:RegisterEffect(e1)
	
	-- Return to hand effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.retcon)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
	
	-- Destroy and inflict damage effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)

	-- Custom Link Summon condition
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCondition(s.linkcon)
	e4:SetOperation(s.linkop)
	e4:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e4)
end

-- CUSTOM LINK SUMMON INIT 

-- Material filter
function s.matfilter(c,lc,sumtype,tp)
	return c:IsCode(270000402)
end
-- Link Summon using Kiryu
-- Custom Link Summon condition
function s.linkcon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return zone>0 and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)==1
end

-- Custom Link Summon operation
function s.linkop(e,tp,eg,ep,ev,re,r,rp,c,og)
	local tp=c:GetControler()
	local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
end

-- CUSTOM LINK SUMMON END


-- Check if the effect can be activated
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Target 1 face-up card on the field to return to hand
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
end

-- Return the target to the hand
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

-- Target 1 face-down card on the opponent's field
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SelectTarget(tp,Card.IsFacedown,tp,,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end

-- Destroy the target and inflict damage if it's a Spell/Trap
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsType(TYPE_SPELL+TYPE_TRAP) then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
