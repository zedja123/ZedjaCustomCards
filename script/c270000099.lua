--Albaz, the Fallen
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Material: 1 Code: 68468459 OR 1 Fusion Monster + 1+ monsters on the field
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.ffilter1,1,1,s.ffilter2,1,99,true) 
	
	-- Special Summon by tributing 1 Fusion Monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e1)
	--Change name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(CARD_ALBAZ)
	c:RegisterEffect(e2)
end

-- Fusion Materials: Code 68468459 or 1 Fusion Monster + 1+ monsters on the field
function s.ffilter1(c)
	return c:IsCode(68468459) or c:IsType(TYPE_FUSION)
end

-- Allow monsters from either player's field
function s.ffilter2(c,fc,sumtype,tp)
	return c:IsOnField() and c:IsControler(tp) or c:IsControler(1-tp) -- allow from either player's field
end

-- Special Summon condition: Tribute 1 Fusion Monster you control
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and
		Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION)
end

-- Operation: Tribute 1 Fusion Monster and Special Summon this card
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_MZONE,0,1,1,nil,TYPE_FUSION)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end